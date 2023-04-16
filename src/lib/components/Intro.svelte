<script lang="ts">
	import ProfileImage from '$lib/assets/profile.png?w=175&h=175&webp'; // LSP complains here but it's a thing I pinky promise

	import skills from '$lib/skills';
	import type { Song } from '$lib/types';

	export let data: { song: Song };
</script>

<!-- fancy blurred background gradient -->
<div class="w-screen h-screen fixed top-0 left-0 flex justify-center items-center">
	<div
		class="w-200 h-64 fixed bg-gradient-to-r from-teal-500 to-blue-500 opacity-30 filter blur-superxl rounded-oval"
	/>
</div>

<div class="w-screen h-screen flex justify-center items-center gap-8 fixed top-0 left-0">
	<img src={ProfileImage} alt="Profile" class="rounded-full shadow-2xl" />

	<div class="flex flex-col justify-center gap-2">
		<h1 class="text-5xl">Hey! I'm <strong>Andrew</strong>.</h1>
		<h2 class="text-3xl">I'm a <strong>Full-Stack</strong> web developer.</h2>
		<div class="flex gap-2">
			{#each skills as skill}
				<a href={skill.href}>
					<img src={skill.src} class="w-10" alt={skill.alt} />
				</a>
			{/each}
		</div>
		<div class="bottom-8">
			{#if data.song.isPlaying}
				<a href={data.song.songUrl} target="_blank">
					<span class="text-xl opacity-50 hover:opacity-75 transition">
						Now Playing:
						<strong>{data.song.artist} - {data.song.title}</strong>
					</span>
				</a>
			{/if}
		</div>
	</div>
</div>

<style>
	.blur-superxl {
		filter: blur(7rem);
	}

	.rounded-oval {
		border-radius: 50%;
	}
</style>
