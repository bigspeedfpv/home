import { getNowPlaying, type Artist } from '$lib/server/spotify';

export async function GET() {
	const response = await getNowPlaying();

	if (response.status === 204 || response.status > 400) {
		return new Response(JSON.stringify({ isPlaying: false }), {
			status: 200,
			headers: {
				'content-type': 'application/json'
			}
		});
	}

	const song = await response.json();

	if (!song.item) {
		return new Response(JSON.stringify({ isPlaying: false }), {
			headers: {
				'content-type': 'application/json'
			}
		});
	}

	const isPlaying = song.is_playing;
	let title = song.item.name;
	let artist = song.item.artists.map((_artist: Artist) => _artist.name).join(', ');
	const songUrl = song.item.external_urls.spotify;

	// trim artist and song names
	if (artist.length > 15) {
		artist = artist.substring(0, 15) + '...';
	}
	if (title.length > 25) {
		title = title.substring(0, 25) + '...';
	}

	return new Response(
		JSON.stringify({
			artist,
			isPlaying,
			songUrl,
			title
		}),
		{
			headers: {
				'content-type': 'application/json',
				'cache-control': 'public, s-maxage=60, stale-while-revalidate=30'
			}
		}
	);
}
