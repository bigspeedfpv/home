<script lang="ts">
	import ProfileImage from '$lib/assets/profile.png?w=175&h=175&webp'; // LSP complains here but it's a thing I pinky promise

	import skills from '$lib/skills';
    // This is a bit of a hack to get the skills to wrap nicely on smaller screens
    // it'll add a break roughly halfway instead of at the first one that doesn't fit
    let skillsHalfwayPoint = Math.ceil(skills.length / 2);

	import type { Song } from '$lib/types';
	export let data: { song: Song };
</script>

<!-- fancy blurred background gradient -->
<div class="w-screen h-screen fixed top-0 left-0 flex justify-center items-center">
	<div
		class="w-200 h-64 fixed bg-gradient-to-r from-teal-500 to-blue-500 opacity-30 filter blur-superxl rounded-oval"
	/>
</div>

<div class="w-screen h-screen flex flex-col md:flex-row justify-center items-center p-6 gap-4 md:gap-8 fixed top-0 left-0">
	<img src={ProfileImage} alt="Profile" class="rounded-full shadow-2xl" />

	<div class="flex flex-col justify-center align-center md:align-left gap-4 md:gap-2">
		<h1 class="text-5xl text-center md:text-left">Hey! I'm <strong>Andrew</strong>.</h1>
		<h2 class="text-3xl text-center md:text-left">I'm a <strong>Full-Stack</strong> web developer.</h2>
		<div class="whitespace-nowrap text-center md:text-left">
			{#each skills as skill, index}
				<a href={skill.href}>
					<img src={skill.src} class="inline-block w-10" alt={skill.alt} />
				</a>
                {#if skillsHalfwayPoint === index + 1}
                    <wbr />
                {/if}
			{/each}
		</div>
		<div class="bottom-8">
			{#if data.song.isPlaying}
				<a href={data.song.songUrl} target="_blank">
					<span class="text-xl opacity-50 hover:opacity-75 transition text-center md:text-left">
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
