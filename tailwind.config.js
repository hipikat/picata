/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/styles/main.sass", "./src/**/*.html", "./src/**/*.js"],
  theme: {
    extend: {
      colors: {
        "light-green-gray": "#e9f0e9", // Custom color
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
