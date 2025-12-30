/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        fof: {
          orange: '#FF8C00',
          black: '#000000',
          gray: '#1A1A1A'
        }
      },
      backgroundImage: {
        'fof-gradient': "linear-gradient(135deg, #FF8C00 0%, #000000 100%)",
      }
    },
  },
  plugins: [],
}
