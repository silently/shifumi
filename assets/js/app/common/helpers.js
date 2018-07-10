export function nextFrame(fun) {
  // In React sometimes we want to get the next frame after a render
  // and the render may happen in the first requested animation frame
  // so we ask for the one just after
  return requestAnimationFrame(() => requestAnimationFrame(fun))
}
