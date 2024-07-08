<script lang="ts">
	import type { Song } from '$lib/types';

	// song data loaded in ssr
	export let song: Song;

	const mock: Song = {
		isPlaying: true,
		song: {
			title: 'California Gurls',
			url: 'https://open.spotify.com/track/6KOEK6SeCEZOQkLj5M1PxH'
		},
		artists: [
			{
				name: 'Katy Perry',
				url: 'https://open.spotify.com/artist/6jJ0s89eD6GaHleKKya26X'
			},
			{
				name: 'Katy Perry',
				url: 'https://open.spotify.com/artist/6jJ0s89eD6GaHleKKya26X'
			}
		],
		album: {
			coverUrl: 'https://i.scdn.co/image/ab67616d0000b273d20c38f295039520d688a888',
			url: 'https://open.spotify.com/album/2eQMC9nJE3f3hCNKlYYHL1'
		}
	};

	song = song.isPlaying ? song : mock;
</script>

<div class="flex items-end justify-center fixed left-0 bottom-0 mb-4 overflow-hidden w-full">
	<div
		class="flex gap-4 justify-center items-center px-4 py-2 border-1 border-white/10 rounded-md shadow-lg bg-gray-900/5 backdrop-blur-lg">
		<a href={song.album.url} target="_blank">
			<img
				src={song.album.coverUrl}
				alt="Album cover for {song.song.title}"
				class="w-10 h-10 rounded-md shadow-md" />
		</a>
		<div class="flex flex-col">
			<span class="text-xs -mb-0.5 font-light opacity-55">Listening to</span>
			<a href={song.song.url} target="_blank" class="font-bold link-underline -mb-1">
				{song.song.title}
			</a>
			<!-- set font size to 0 to hide line break spaces -->
			<span class="text-[0px]">
				<span class="font-light opacity-60 text-sm">by&nbsp;</span>
				{#each song.artists as artist, i}
					<a
						href={artist.url}
						target="_blank"
						class="link-underline font-medium opacity-80 text-sm">
						{artist.name}
					</a>
					<span class="font-light opacity-60 text-sm">
						{#if i !== song.artists.length - 1 && song.artists.length > 2},&nbsp;{/if}{#if song.artists.length === 2}&nbsp;{/if}{#if i === song.artists.length - 2}and&nbsp;{/if}
					</span>
				{/each}
			</span>
		</div>
	</div>
</div>
