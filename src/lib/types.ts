export type HomeLoadData = {
	song: Song;
};

export type Song = {
	artist: string;
	isPlaying: boolean;
	songUrl: string;
	title: string;
};
