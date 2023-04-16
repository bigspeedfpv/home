<script lang="ts">
	import type { Song } from '$lib/types';

	export let song: Song;
</script>

{#if song.isPlaying}
	<a href={song.songUrl} target="_blank">
		<span class="text-xl opacity-50 hover:opacity-75 transition">
            Now Playing:
			<strong>{song.artist} - {song.title}</strong>
		</span>
	</a>
{/if}
