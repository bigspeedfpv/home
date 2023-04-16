import NodeIcon from './node.svg';
import TypescriptIcon from './typescript.svg';
import ReactIcon from './react.svg';
import VueIcon from './vue.svg';
import SvelteIcon from './svelte.svg';
import RustIcon from './rust.svg';
import GoIcon from './go.svg';
import PythonIcon from './python.svg';

type Skill = {
	src: string;
	alt: string;
	href: string;
};

const skills: Skill[] = [
	{ src: NodeIcon, alt: 'Node.js', href: 'https://nodejs.org/' },
	{ src: TypescriptIcon, alt: 'TypeScript', href: 'https://www.typescriptlang.org/' },
	{ src: ReactIcon, alt: 'React', href: 'https://reactjs.org/' },
	{ src: VueIcon, alt: 'Vue', href: 'https://vuejs.org/' },
	{ src: SvelteIcon, alt: 'Svelte', href: 'https://svelte.dev/' },
	{ src: RustIcon, alt: 'Rust', href: 'https://www.rust-lang.org/' },
	{ src: GoIcon, alt: 'Go', href: 'https://golang.org/' },
	{ src: PythonIcon, alt: 'Python', href: 'https://www.python.org/' }
];

export default skills;
