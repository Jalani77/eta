import Agenda from 'agenda';

import { defineJobs } from '../v1/jobs/index.js';

export async function createAgenda(mongoUri) {
  const agenda = new Agenda({
    db: {
      address: mongoUri,
      collection: 'jobs',
    },
    processEvery: '10 seconds',
  });

  defineJobs(agenda);

  await agenda.start();
  return agenda;
}
