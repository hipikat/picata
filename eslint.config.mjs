// @ts-check

import eslint from "@eslint/js";
import react from "eslint-plugin-react";
import tseslint from "typescript-eslint";
import tailwind from "eslint-plugin-tailwindcss";
import tsParser from "@typescript-eslint/parser";

export default tseslint.config(
  {
    ignores: [
      ".git/**",
      ".pytest_cache/**",
      ".ruff_cache/**",
      ".venv/**",
      "__pycache__/**",
      "build/**",
      "dist/**",
      "infra/**",
      "lib/**",
      "logs/**",
      "media/**",
      "node_modules/**",
      "snapshots/**",
      "src/migrations/**",
      "static/**",
    ],
  },
  {
    files: ["**/*.{js,mjs,cjs,jsx,mjsx,ts,tsx,mtsx}"],
    languageOptions: {
      ecmaVersion: "latest",
      parser: tsParser,
      sourceType: "module",
      globals: {
        process: "readonly",
        window: "readonly",
        document: "readonly",
        navigator: "readonly",
        console: "readonly",
      },
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
  },
  eslint.configs.recommended,
  react.configs.flat.recommended,
  tseslint.configs.recommended,
  tailwind.configs["flat/recommended"],
  {
    settings: {
      tailwindcss: {
        config: "tailwind.config.mjs",
        rules: {
          "no-custom-classname": "off",
        },
      },
      react: {
        version: "detect",
      },
    },
    rules: {
      "tailwindcss/no-custom-classname": "off",
    },
  },
);
