const nonConcurrent = async () => {
  console.time('nonConcurrent');

  const ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  const results = [];

  for (const id of ids) {
    const result = await fetch(`https://xkcd.com/${id}/info.0.json`)
      .then((res) => res.json())
      .then((data) => data);

    results.push(result);
  }

  // console.log({ nonConcurrent: results });
  console.timeEnd('nonConcurrent');
};

const concurrent = async () => {
  console.time('concurrent');

  const ids = [11, 22, 33, 44, 55, 66, 77, 88, 99, 100];

  const promises = ids.map((id) => {
    return fetch(`https://xkcd.com/${id}/info.0.json`)
      .then((res) => res.json())
      .then((data) => data);
  });

  const result = await Promise.all(promises);
  // console.log({ concurrent: result });
  console.timeEnd('concurrent');
};

const main = async () => {
  await nonConcurrent();
  await concurrent();
};

main();
