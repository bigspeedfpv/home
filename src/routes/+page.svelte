<script lang="ts">
	import skills from '$lib/skills';
	// This is a bit of a hack to get the skills to wrap nicely on smaller screens
	// it'll add a break roughly halfway instead of at the first one that doesn't fit
	let skillsHalfwayPoint = Math.ceil(skills.length / 2);

	import { icons } from '@iconify-json/carbon';
	import { getIconData } from '@iconify/utils';
	import Icon from '@iconify/svelte';

	const i = (icon: string) => getIconData(icons, icon);

	const links = [
		{ name: 'GitHub', iconData: 'carbon:logo-github', href: 'https://github.com/bigspeedfpv' },
		{
			name: 'LinkedIn',
			icon: i('logo-linkedin'),
			href: 'https://www.linkedin.com/in/andrew-brower-6366a9251/'
		},
		{
			name: 'Discord',
			icon: i('logo-discord'),
			href: 'https://discord.com/users/277822562116042753'
		},
		{
			name: 'Instagram',
			icon: i('logo-instagram'),
			href: 'https://www.instagram.com/bigspeedfpv/'
		},
		{ name: 'YouTube', icon: i('logo-youtube'), href: 'https://youtube.com/@bigspeedfpv' }
	];
</script>

<svelte:head>
	<title>Andrew Brower</title>
	<link rel="canonical" href="https://bigspeed.me" />
	<meta name="description" content="Andrew Brower (bigspeed)'s homepage." />
</svelte:head>

<section>
	<div class="w-screen h-screen flex justify-center overflow-hidden">
		<!-- fancy blurred background gradient -->
		<div class="w-screen h-screen fixed top-0 left-0 flex justify-center items-center">
			<div
				class="w-[50rem] h-64 fixed bg-gradient-to-r from-teal-500 to-blue-500 opacity-30 blur-superxl rounded-oval">
			</div>
		</div>

		<div
			class="w-screen h-screen flex flex-col md:flex-row justify-center items-center p-6 gap-4 md:gap-8 fixed top-0 left-0">
			<enhanced:img
				src="$lib/assets/profile.png"
				alt="Profile"
				class="rounded-full shadow-2xl w-32 h-32 md:w-48 md:h-48">
			</enhanced:img>

			<div class="flex flex-col justify-center align-center md:align-left gap-4 md:gap-2">
				<h1 class="text-5xl text-center md:text-left">
					Hey! I'm <strong>Andrew.</strong>
				</h1>
				<h2 class="text-3xl text-center md:text-left">
					I'm a <strong>Software Engineer.</strong>
				</h2>

				<div class="whitespace-nowrap text-center md:text-left">
					{#each skills as skill, index}
						<a href={skill.href}>
							<img src={skill.src} class="inline-block h-10 w-10" alt={skill.alt} />
						</a>
						{#if skillsHalfwayPoint === index + 1}
							<wbr />
						{/if}
					{/each}
				</div>

				<!-- links -->
				<div class="flex justify-center md:justify-start">
					{#each links as link}
						{#if link.icon}
							<a href={link.href} target="_blank" title={link.name}>
								<Icon
									icon={link.icon}
									width="40px"
									height="40px"
									class="opacity-50 hover:opacity-75 transition" />
							</a>
						{/if}
					{/each}
				</div>
			</div>
		</div>
	</div>
</section>

<style>
	.blur-superxl {
		filter: blur(7rem);
	}

	.rounded-oval {
		border-radius: 50%;
	}
</style>
