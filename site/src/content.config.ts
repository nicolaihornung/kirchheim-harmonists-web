import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const events = defineCollection({
	loader: glob({ pattern: '**/*.md', base: './src/data/events' }),
	schema: z.object({
		title: z.string(),
		date: z.coerce.date(),
		receptionTime: z.string().optional(),
		startTime: z.string(),
		venue: z.string(),
		city: z.string(),
		ensembles: z.array(z.object({
			name: z.string(),
			logo: z.string().optional(),
		})).default([]),
		admission: z.string().default('Eintritt frei'),
	}),
});

export const collections = { events };
