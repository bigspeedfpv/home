<template>
  <div class="full flex">
    <div class="flex row">
      <div class="flex col start">
        <h1>Andrew Brower</h1>
        <span>Full-Stack Web Developer<br />and FPV Pilot</span>
      </div>
      <div class="divider" />
      <div class="flex col end">
        <NuxtLink to="/about" title="About">About</NuxtLink>
        <NuxtLink to="/projects" title="Projects">Projects</NuxtLink>
        <a href="https://github.com/bigspeedfpv" title="GitHub">GitHub</a>
      </div>
    </div>
  </div>
</template>

<script></script>

<style scoped>
.full {
  width: 100%;
  height: 100%;
}

.flex {
  display: flex;
  justify-content: center;
}

.col {
  flex-direction: column;
  gap: 0.75rem;
}

.col.start {
  align-items: flex-end;
  text-align: end;
}

.col.end {
  align-items: flex-start;
}

.row {
  flex-direction: row;
  align-items: center;
  gap: 1.5rem;
}

.divider {
  width: 1px;
  height: 100px;
  background: var(--brand-white);
  opacity: 25%;
}

a {
  color: var(--brand-white);
  font-weight: normal;
  font-size: 1.1rem;
  transition: font-weight 0.2s ease-in-out;
}

a:hover {
  font-weight: 600;
}

a::after {
  display: block;
  content: attr(title);
  font-weight: 600;
  height: 1px;
  color: transparent;
  overflow: hidden;
  visibility: hidden;
}

@media (max-width: 500px) {
  .row {
    flex-direction: column;
    gap: 1.25rem;
  }

  .col {
    align-items: center !important;
    text-align: center !important;
  }

  .divider {
    width: 150px;
    height: 1px;
  }
}
</style>
