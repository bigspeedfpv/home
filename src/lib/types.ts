export type Song = {
	isPlaying: boolean;
	artists: {
		name: string;
		url: string;
	}[];
	song: {
		title: string;
		url: string;
	};
	album: {
		coverUrl: string;
		url: string;
	};
};
