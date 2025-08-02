// Importieren der erforderlichen Firebase-Funktionen und Admin-SDKs
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { CloudTasksClient } = require("@google-cloud/tasks");

// Firebase Admin SDK initialisieren
admin.initializeApp();

// Cloud Tasks Client initialisieren
const tasksClient = new CloudTasksClient();

// Funktion zum Planen einer Push-Benachrichtigung als Cloud Task
exports.scheduleReminder = functions.firestore
  .document("events/{eventId}")
  .onCreate(async (snap, context) => {
    try {
      // Die Daten des neuen Events abrufen
      const eventData = snap.data();
      const {
        hasReminder,
        reminderOffset,
        singleEventName,
        singleEventDate,
        acceptedMemberIds,
      } = eventData;

      // Überprüfen, ob die notwendigen Daten für eine Erinnerung vorhanden sind
      if (
        !hasReminder ||
        !reminderOffset ||
        !singleEventDate ||
        !acceptedMemberIds ||
        acceptedMemberIds.length === 0
      ) {
        console.log("Keine Erinnerungseinstellungen gefunden oder keine Teilnehmer. Erinnerung nicht geplant.");
        return null;
      }

      // Projekt-ID und Warteschlangen-Namen definieren
      const project = process.env.GCLOUD_PROJECT;
      const location = "us-central1"; // Muss mit dem Standort Ihrer Funktion übereinstimmen
      const queue = "push-notification-queue";
      const parent = tasksClient.queuePath(project, location, queue);

      // Den Erinnerungszeitpunkt basierend auf dem Offset berechnen
      const eventTimestamp = singleEventDate.toDate();
      const reminderTimestamp = new Date(eventTimestamp.getTime());

      switch (reminderOffset) {
        case "10 Sekunden":
          reminderTimestamp.setSeconds(reminderTimestamp.getSeconds() - 10);
          break;
        case "30 Minuten":
          reminderTimestamp.setMinutes(reminderTimestamp.getMinutes() - 30);
          break;
        case "1 Stunde":
          reminderTimestamp.setHours(reminderTimestamp.getHours() - 1);
          break;
        case "1 Tag":
          reminderTimestamp.setDate(reminderTimestamp.getDate() - 1);
          break;
        case "1 Woche":
          reminderTimestamp.setDate(reminderTimestamp.getDate() - 7);
          break;
        default:
          console.log(`Unbekannter Erinnerungs-Offset: ${reminderOffset}. Erinnerung nicht geplant.`);
          return null;
      }

      // Überprüfen, ob der geplante Erinnerungszeitpunkt in der Vergangenheit liegt
      if (reminderTimestamp.getTime() < Date.now()) {
        console.log("Erinnerungszeitpunkt liegt in der Vergangenheit. Erinnerung nicht geplant.");
        return null;
      }

      // Payload für die Cloud Task definieren
      const body = {
        reminderMessage: `Erinnerung: Der Termin "${singleEventName}" beginnt bald!`,
        eventId: snap.id,
        acceptedMemberIds: acceptedMemberIds,
      };

      // Den Task-Body in ein JSON-String konvertieren und Base64-kodieren
      const taskBody = Buffer.from(JSON.stringify(body)).toString("base64");

      const task = {
        httpRequest: {
          httpMethod: "POST",
          url: `https://${location}-${project}.cloudfunctions.net/sendPushNotification`,
          body: taskBody,
          headers: {
            "Content-Type": "application/json",
          },
          oidcToken: {
            serviceAccountEmail: `${project}@appspot.gserviceaccount.com`,
          },
        },
        scheduleTime: {
          seconds: reminderTimestamp.getTime() / 1000,
        },
      };

      // Den Cloud Task erstellen
      console.log(`Versuche, eine Cloud Task für das Event "${singleEventName}" zu erstellen.`);
      const [response] = await tasksClient.createTask({
        parent,
        task,
      });
      console.log(`Cloud Task ${response.name} erfolgreich erstellt.`);

      return null;
    } catch (error) {
      console.error("Fehler beim Planen der Cloud Task:", error);
      return null;
    }
  });

// Zweite Funktion: Wird von der Cloud Task ausgelöst, um die Benachrichtigung zu senden
exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
  try {
    // Den Base64-kodierten Body dekodieren und parsen
    const decodedBody = Buffer.from(req.body, 'base64').toString('utf-8');
    const { reminderMessage, eventId, acceptedMemberIds } = JSON.parse(decodedBody);

    if (!reminderMessage || !eventId || !acceptedMemberIds) {
      console.error("Ungültiger Payload von Cloud Tasks.");
      res.status(400).send("Bad Request: Missing data in payload.");
      return;
    }

    const payload = {
      notification: {
        title: "Termin-Erinnerung",
        body: reminderMessage,
      },
      data: {
        eventId: eventId,
      },
    };

    const userTokens = [];
    // Abrufen der FCM-Tokens für alle Teilnehmer
    for (const memberId of acceptedMemberIds) {
      const userDoc = await admin.firestore()
        .collection("users").doc(memberId).get();
      if (userDoc.exists && userDoc.data().fcmToken) {
        userTokens.push(userDoc.data().fcmToken);
      }
    }

    // Senden der Benachrichtigung, wenn Tokens gefunden wurden
    if (userTokens.length > 0) {
      const response = await admin.messaging()
        .sendToDevice(userTokens, payload);
      console.log("Benachrichtigung erfolgreich gesendet:", response);
      res.status(200).send("Notification sent successfully.");
    } else {
      console.log("Keine Tokens gefunden, Benachrichtigung nicht gesendet.");
      res.status(200).send("No tokens found, notification not sent.");
    }
  } catch (error) {
    console.error("Fehler beim Senden der Benachrichtigung:", error);
    res.status(500).send("Internal Server Error.");
  }
});
