export default defineNuxtConfig({
  app: {
    head: {
      title: "bigspeed",
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
