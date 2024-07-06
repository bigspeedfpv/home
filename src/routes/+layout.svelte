<script lang="ts">
	import NowPlaying from '$lib/components/NowPlaying.svelte';
	import '../app.css';

	import type { Song } from '$lib/types';

	import { dev } from '$app/environment';

	// song data loaded in ssr
	export let data: { song: Song };
</script>

<svelte:head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</svelte:head>

<div class="bg-gray-950 text-gray-50/87">
	<slot />

	{#if data.song.isPlaying || dev}
		<NowPlaying song={data.song} />
	{/if}
</div>
