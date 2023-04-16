<script>
	import '@unocss/reset/tailwind.css';
	import 'uno.css';
</script>

<svelte:head>
	<style uno:preflights uno:safelist global></style>
</svelte:head>

<div class="bg-gray-950 text-white">
	<slot />
</div>

<style>
	* {
		box-sizing: border-box;
	}
</style>
