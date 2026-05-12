export const formatRelativeDate = (isoDate: string) => {
  const now = new Date().getTime();
  const date = new Date(isoDate).getTime();
  const diff = Math.abs(now - date);

  const minute = 60 * 1000;
  const hour = minute * 60;
  const day = hour * 24;
  const week = day * 7;
  const month = day * 30;
  const year = day * 365;

  if (diff < minute) {
    return 'just now';
  }

  const getPlural = (value: number, unit: string) =>
    `${value} ${unit}${value > 1 ? 's' : ''}`;

  const getRelative = (value: number, unit: string) =>
    date > now
      ? `in ${getPlural(value, unit)}`
      : `${getPlural(value, unit)} ago`;

  if (diff < hour) {
    return getRelative(Math.floor(diff / minute), 'minute');
  }
  if (diff < day) {
    return getRelative(Math.floor(diff / hour), 'hour');
  }
  if (diff < week) {
    return getRelative(Math.floor(diff / day), 'day');
  }
  if (diff < month) {
    return getRelative(Math.floor(diff / week), 'week');
  }
  if (diff < year) {
    return getRelative(Math.floor(diff / month), 'month');
  }
  return getRelative(Math.floor(diff / year), 'year');
};
