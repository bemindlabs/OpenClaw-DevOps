import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
  ]),
  {
    rules: {
      // Allow unused vars with underscore prefix
      "@typescript-eslint/no-unused-vars": [
        "warn",
        { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
      ],
      // Allow any type (will address in future)
      "@typescript-eslint/no-explicit-any": "off",
      // Allow require() imports (used for dynamic imports)
      "@typescript-eslint/no-require-imports": "off",
      // Disable ref access warning (TODO: fix use-socket.ts)
      "react-hooks/refs": "off",
      // Allow anonymous default exports
      "import/no-anonymous-default-export": "off",
    },
  },
]);

export default eslintConfig;
