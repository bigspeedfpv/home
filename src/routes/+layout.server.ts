import type { LayoutServerLoad } from './$types';
import { dev } from '$app/environment';

export const csr = dev; // homepage doesn't have any interactivity

export const load: LayoutServerLoad = async ({ fetch }) => {
	const song = await fetch('/api/spotify/np').then((r) => r.json());

	return {
		song
	};
};
