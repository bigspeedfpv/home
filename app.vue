<template>
  <NuxtPage />

  <div class="container">
    <div class="nav">
      <NuxtLink to="/" :class="{ inactive: $route.path !== '/' }" title="Home">
        Home
      </NuxtLink>
      <NuxtLink
        to="/blog"
        :class="{ inactive: !$route.path.includes('/blog') }"
        title="Blog"
      >
        Blog
      </NuxtLink>
      <NuxtLink
        to="/portfolio"
        :class="{ inactive: $route.path !== '/portfolio' }"
        title="Portfolio"
      >
        Portfolio
      </NuxtLink>
      <a
        href="https://github.com/bigspeedfpv/home"
        target="_blank"
        class="inactive"
      >
        Source
      </a>
    </div>
  </div>
</template>

<style scoped>
.container {
  position: absolute;
  bottom: 0;
  width: 100%;
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 10px;

  font-size: 1rem;
}

.nav {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem;

  height: 100%;
  border: var(--brand-black) 1px solid;
  border-radius: 0.5rem;
  filter: drop-shadow(0px 4px 4px rgba(0, 0, 0, 0.5));

  background: var(--brand-background);
  color: var(--brand-white);
}

.inactive {
  color: var(--brand-white);
  font-weight: normal;
}

a {
  text-align: center;
  transition: color 0.2s ease-in-out;
}

a::after {
  display: block;
  content: attr(title);
  font-weight: bold;
  height: 1px;
  color: transparent;
  overflow: hidden;
  visibility: hidden;
}
</style>
