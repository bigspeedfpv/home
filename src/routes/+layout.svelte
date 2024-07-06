<script>
	import '../app.css';
</script>

<svelte:head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</svelte:head>

<div>
	<slot />
</div>

<style>
	:global(html) {
		background-color: rgb(3 7 18);
		color: white;
	}
</style>
