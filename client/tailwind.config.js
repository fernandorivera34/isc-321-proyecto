// tailwind.config.js
module.exports = {
  theme: {
    darkMode: "class",
    extend: {
      keyframes: {
        gradient: {
          "0%": { backgroundPosition: "0% 50%" },
          "25%": { backgroundPosition: "50% 100%" },
          "50%": { backgroundPosition: "100% 50%" },
          "75%": { backgroundPosition: "50% 0%" },
          "100%": { backgroundPosition: "0% 50%" },
        },
      },
      animation: {
        gradient: "gradient 6s ease-in-out infinite",
      },

      // Custom colors
      colors: {
        primary: {
          DEFAULT: "#1e3976",
        },
      },
    },
  },
};
