import OcamlIcon from './ocaml.svg';
import RustIcon from './rust.svg';
import NodeIcon from './node.svg';
import TypescriptIcon from './typescript.svg';
import GoIcon from './go.svg';
import ReactIcon from './react.svg';
import VueIcon from './vue.svg';
import SvelteIcon from './svelte.svg';
import PythonIcon from './python.svg';

type Skill = {
	src: string;
	alt: string;
	href: string;
};

const skills: Skill[] = [
	{ src: OcamlIcon, alt: 'OCaml', href: 'https://ocaml.org' },
	{ src: RustIcon, alt: 'Rust', href: 'https://www.rust-lang.org/' },
	{ src: NodeIcon, alt: 'Node.js', href: 'https://nodejs.org/' },
	{ src: TypescriptIcon, alt: 'TypeScript', href: 'https://www.typescriptlang.org/' },
	{ src: GoIcon, alt: 'Go', href: 'https://golang.org/' },
	{ src: ReactIcon, alt: 'React', href: 'https://reactjs.org/' },
	{ src: VueIcon, alt: 'Vue', href: 'https://vuejs.org/' },
	{ src: SvelteIcon, alt: 'Svelte', href: 'https://svelte.dev/' },
	{ src: PythonIcon, alt: 'Python', href: 'https://www.python.org/' }
];

export default skills;
