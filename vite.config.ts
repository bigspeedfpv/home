import UnoCSS from 'unocss/vite';

import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { imagetools } from 'vite-imagetools';

export default defineConfig({
	plugins: [imagetools(), sveltekit(), UnoCSS()]
});
