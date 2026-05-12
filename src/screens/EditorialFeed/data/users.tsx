export type User = {
  id: string;
  name: string;
  initials: string;
  avatarUri: string;
  avatarColor: 0 | 1 | 2 | 3;
  jobTitle: string;
  companyName: string;
};

export const usersData: User[] = [
  {
    id: 'f2c53b44-8b3a-46c9-a6c4-ec0b3ca7c0e1',
    name: 'Camille Bourgeois',
    initials: 'CB',
    avatarColor: 1,
    avatarUri: 'https://xsgames.co/randomusers/assets/avatars/female/29.jpg',
    jobTitle: 'Front-end Developer',
    companyName: 'Zinga',
  },
  {
    id: 'f7b6c5a6-6b47-4532-9f49-6f7e7bf3c11d',
    name: 'Stéphane Roussel',
    initials: 'SR',
    avatarColor: 1,
    avatarUri: 'https://xsgames.co/randomusers/assets/avatars/male/4.jpg',
    jobTitle: 'Full Stack Developer',
    companyName: 'Initech',
  },
  {
    id: '9cfaa6c1-4ba4-4bad-a5c1-3b9a9bf3c2f9',
    name: 'Isabelle Girard',
    initials: 'IG',
    avatarColor: 3,
    avatarUri: 'https://xsgames.co/randomusers/assets/avatars/female/27.jpg',
    jobTitle: 'Web Engineer Advocate',
    companyName: 'Fentech',
  },
  {
    id: 'd2c0d2c9-ecb8-4ed8-8b19-16be4d24fba8',
    name: 'Lucas Perrin',
    initials: 'LP',
    avatarColor: 3,
    avatarUri: '',
    jobTitle: 'DevOps Engineer',
    companyName: 'Reswork',
  },
  {
    id: 'd2c0d2c9-ea1f-41f8-8b19-16be4d24fba8',
    name: 'Lucie Mouton',
    initials: 'LM',
    avatarColor: 3,
    avatarUri: 'https://xsgames.co/randomusers/assets/avatars/female/32.jpg',
    jobTitle: 'Mobile Developer',
    companyName: 'Flibberflabber',
  },
  {
    id: 'd2c0d2c9-ea2f-41f8-8b19-16be4d24fbd8',
    name: 'Mathieu Girard',
    initials: 'MG',
    avatarColor: 3,
    avatarUri: 'https://xsgames.co/randomusers/assets/avatars/male/32.jpg',
    jobTitle: 'Scientist',
    companyName: 'CERN',
  },
];
