module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],
    "object-curly-spacing": "off",
    "indent": "off",
    "max-len": "off",
  },
};
