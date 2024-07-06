import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { imagetools } from 'vite-imagetools';
import tailwindcss from "@tailwindcss/vite";
import Icons from 'unplugin-icons/vite';

export default defineConfig({
    plugins: [
        Icons({
            compiler: 'svelte'
        }),
        imagetools(),
        sveltekit(),
        tailwindcss(),
    ]
});
