/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./frontend/**/*.{html,js}"],
  theme: {
    extend: {
      colors: {
        purple_0: "#10002b",
        purple_1: "#240046",
        purple_2: "#3c096c",
        purple_3: "#3c096c",
        purple_4: "#5a189a",
        purple_5: "#7b2cbf",
        purple_6: "#9d4edd",
        purple_7: "#c77dff",
        purple_8: "#e0aaff"
      },
      keyframes: {
        dot1: {
          '0%': { transform: 'translateY(0)' },
          '16%': { transform: 'translateY(-3px)' },
          '32%': { transform: 'translateY(-7px)' },
          '48%': { transform: 'translateY(-3px)' },
          '64%': { transform: 'translateY(0)' },
          '80%': { transform: 'translateY(0)' },
          '100%': { transform: 'translateY(0)' },
        },
        dot2: {
          '0%': { transform: 'translateY(0)' },
          '16%': { transform: 'translateY(0)' },
          '32%': { transform: 'translateY(-3px)' },
          '48%': { transform: 'translateY(-7px)' },
          '64%': { transform: 'translateY(-3px)' },
          '80%': { transform: 'translateY(0)' },
          '100%': { transform: 'translateY(0)' },
        },
        dot3: {
          '0%': { transform: 'translateY(0)' },
          '16%': { transform: 'translateY(0)' },
          '32%': { transform: 'translateY(0)' },
          '48%': { transform: 'translateY(-3px)' },
          '64%': { transform: 'translateY(-7px)' },
          '80%': { transform: 'translateY(-3px)' },
          '100%': { transform: 'translateY(0)' },
        },
      },
      animation: {
        dot1: 'dot1 1s linear infinite',
        dot2: 'dot2 1s linear infinite',
        dot3: 'dot3 1s linear infinite',
      },
    },
  },
  plugins: [],
}

