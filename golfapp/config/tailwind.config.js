const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
  ],
  theme: {
    extend: {
      colors: {
        // --- Custom Color Palette ---

        // Primary: Deep, rich forest green for main branding, headers, strong CTAs
        'primary': '#1A472A', // A dark, sophisticated forest green

        // Secondary: A slightly lighter or more muted green for secondary elements, hover states
        'secondary': '#2F624C', // A slightly warmer, less intense green

        // Accent: A warm, earthy yellow or gold that complements green beautifully
        'accent': '#DAA520', // Goldenrod - great for highlights, active states, important notices

        // Neutrals (for backgrounds, borders, non-highlighted text)
        'neutral-lightest': '#F9FAFB', // Very light gray, almost white, for main backgrounds
        'neutral-light': '#E5E7EB',    // Light gray for subtle borders, card backgrounds
        'neutral-medium': '#9CA3AF',   // Medium gray for secondary text, disabled states
        'neutral-dark': '#1F2937',     // Dark gray for primary text, icons (strong readability)

        // Text colors on specific backgrounds (useful to define explicitly)
        'text-on-primary': '#FFFFFF', // White text for use on primary backgrounds
        'text-on-accent': '#1F2937',  // Dark text for use on accent backgrounds (ensure contrast)
      },

      // --- Other extensions (from previous suggestions) ---
      fontFamily: {
        sans: ['Inter', 'sans-serif'],    // Your main body font
        heading: ['Montserrat', 'sans-serif'], // Your heading font
      },
      borderRadius: {
        'xl': '0.75rem',
        '2xl': '1rem',
        '3xl': '1.5rem',
      },
      boxShadow: {
        'custom-sm': '0 1px 2px rgba(0,0,0,0.05)',
        'custom-md': '0 4px 6px rgba(0,0,0,0.1)',
        'custom-lg': '0 10px 15px rgba(0,0,0,0.15)',
      }
    },
  },
  plugins: [],
}
