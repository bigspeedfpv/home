<template>
  <div class="full flex">
    <div class="flex row">
      <div class="flex col align-right">
        <h1>Andrew Brower</h1>
        <span>Full-Stack Web Developer</span>
      </div>
      <div class="divider" />
      <div class="flex col align-left">
        <NuxtLink to="/about">About</NuxtLink>

        <a href="https://github.com/bigspeedfpv">GitHub</a>
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
  align-items: center;
}

.col {
  flex-direction: column;
  gap: 0.75rem;
}

.col.align-right {
  align-items: flex-end;
}

.col.align-left {
  align-items: flex-start;
}

.row {
  flex-direction: row;
  gap: 1.5rem;
}

.divider {
  width: 1px;
  height: 100px;
  background: var(--brand-white);
  opacity: 25%;
}
</style>
