import 'react';

declare module 'react' {
	namespace JSX {
		interface IntrinsicElements {
			marquee: React.DetailedHTMLProps<
				React.HTMLAttributes<HTMLElement>,
				HTMLElement
			>;
		}
	}
}
