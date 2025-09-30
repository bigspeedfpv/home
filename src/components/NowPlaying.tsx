import {
	type Component,
	createMemo,
	createResource,
	type JSXElement,
	Show,
} from "solid-js";

const NowPlaying: Component = () => {
	const fetchStatus = async (): Promise<NowPlayingResponse | undefined> => {
		const res = await fetch(
			import.meta.env.PUBLIC_PROXY_HOST || "https://now-playing.bigspeed.me",
		);
		if (res.status !== 200) {
			console.error(`bad status fetching now playing: ${res.status}`);
			return undefined;
		}

		const json = await res.json();

		if (json.playing === false) return undefined;
		else return json;
	};

	const [status, { refetch: _refetchStatus }] = createResource(fetchStatus);

	// TODO: refresh every 15 sec or so?
	// this will need a style rework to make it look good when appearing/disappearing

	const artistLink = (artist: Artist) => (
		<strong>
			<a target="_blank" href={artist.url}>
				{artist.name}
			</a>
		</strong>
	);

	const artistLine = createMemo(() => {
		const s = status();
		if (s === undefined || s.artists.length === 0) return;
		if (s.artists.length === 1) return artistLink(s.artists[0]);

		const artistLinks = s.artists.map(artistLink);

		return artistLinks.reduce(
			(acc: JSXElement[], artist: JSXElement, idx: number) => {
				acc.push(artist);
				if (idx < artistLinks.length - 2) acc.push(", ");
				if (idx === artistLinks.length - 2) acc.push(", and ");
				return acc;
			},
			[],
		);
	}, status);

	return (
		<Show when={status()}>
			{(status) => (
				<div class="relative top-4 md:absolute md:top-0 md:right-0 border-[1px] border-black/20 p-2 rounded-2xl flex flex-row gap-4 align-center items-center w-64">
					<img
						src={status().images[0].url}
						alt="Album cover"
						class="w-12 h-12 rounded-lg"
					/>
					<div class="flex flex-col">
						<span class="text-xs opacity-50">Listening to</span>
						<span class="font-bold">
							<a target="_blank" href={status().url}>
								{status().name}
							</a>
						</span>
						<span class="text-xs">by {artistLine()}</span>
					</div>
				</div>
			)}
		</Show>
	);
};

export default NowPlaying;

type NowPlayingResponse = {
	playing: true;
	artists: Artist[];
	duration_ms: number;
	progress_ms: number;
	// seconds
	since: number;
	url: string;
	name: string;
	images: { url: string; width: number; height: number }[];
};

type Artist = { url: string; name: string };
