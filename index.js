// log running and wait until the process is killed.
const wait = time => new Promise((resolve, reject) => setTimeout(resolve, time));
async function loop () {
  await wait(1000);
  return loop();
}
async function run () {
  console.log('running...');
  await loop();
}
run();
