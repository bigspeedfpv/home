<script lang="ts">
	import type { Song } from '$lib/types';

	import Intro from '$lib/components/Intro.svelte';

	// song data loaded in ssr
	export let data: { song: Song };
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<section>
	<div class="w-screen h-screen flex justify-center">
		<Intro {data} />
	</div>
</section>
