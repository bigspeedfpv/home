import type { PageServerLoad } from './$types';

export const prerender = true;
export const csr = false; // homepage doesn't have any interactivity

export const load: PageServerLoad = async ({ fetch }) => {
	const song = await fetch('/api/spotify/np').then((r) => r.json());

	return {
		song
	};
};
