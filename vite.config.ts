import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';
import { enhancedImages } from '@sveltejs/enhanced-img';
import Icons from 'unplugin-icons/vite';

export default defineConfig({
	plugins: [
		Icons({
			compiler: 'svelte'
		}),
		sveltekit(),
		tailwindcss(),
		enhancedImages()
	]
});
