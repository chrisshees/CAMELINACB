/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{html,js,ejs}', // Ajusta las rutas según tus archivos
    './public/**/*.html',       // Si tienes vistas en otra carpeta
    './node_modules/flowbite/**/*.{html,js,ejs}'
  ],
  theme: {
    extend: {
      boxShadow: {
        neon: '0 0 5px rgba(255, 20, 147, 0.8), 0 0 10px rgba(255, 20, 147, 0.6), 0 0 20px rgba(255, 20, 147, 0.5), 0 0 40px rgba(255, 20, 147, 0.4)',
      },
      textShadow: {
        neon: '0 0 5px rgba(255, 255, 255, 0.8), 0 0 10px rgba(255, 20, 147, 0.7), 0 0 20px rgba(255, 20, 147, 0.6), 0 0 40px rgba(255, 20, 147, 0.5)',
      },
      colors: {
        beige: {
          100: '#f5f5dc',
          200: '#e3d8b6',
          300: '#d2c69b',
        },
      },
    },
  },
  plugins: [
    require('tailwindcss-textshadow'),
    require('flowbite/plugin')
  ],
}
