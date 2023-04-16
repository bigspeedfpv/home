import {
	SPOTIFY_CLIENT_ID,
	SPOTIFY_CLIENT_SECRET,
	SPOTIFY_REFRESH_TOKEN
} from '$env/static/private';

const basic = Buffer.from(`${SPOTIFY_CLIENT_ID}:${SPOTIFY_CLIENT_SECRET}`).toString('base64');

const TOKEN_ENDPOINT = `https://accounts.spotify.com/api/token`;
const NOW_PLAYING_ENDPOINT = `https://api.spotify.com/v1/me/player/currently-playing`;

const getAccessToken = async () => {
	const response = await fetch(TOKEN_ENDPOINT, {
		method: 'POST',
		headers: {
			Authorization: `Basic ${basic}`,
			'Content-Type': 'application/x-www-form-urlencoded'
		},
		body: new URLSearchParams({
			grant_type: 'refresh_token',
			refresh_token: SPOTIFY_REFRESH_TOKEN
		}).toString()
	});

	return response.json();
};

const getNowPlaying = async () => {
	const { access_token } = await getAccessToken();

	return fetch(NOW_PLAYING_ENDPOINT, {
		headers: {
			Authorization: `Bearer ${access_token}`
		}
	});
};

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

type Artist = {
	external_urls: {
		spotify: string;
	};
	href: string;
	id: string;
	name: string;
	type: string;
	uri: string;
};
