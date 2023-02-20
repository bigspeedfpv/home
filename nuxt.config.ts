// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  app: {
    head: {
      link: [
        { rel: "preconnect", href: "https://rsms.me/" },
        { rel: "stylesheet", href: "https://rsms.me/inter/inter.css" },
      ],
    },
  },
  css: ["modern-normalize/modern-normalize.css", "~/assets/css/main.css"],
  postcss: {
    plugins: {
      autoprefixer: {},
    },
  },
});
