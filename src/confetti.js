function createCanvas() {
  const canvas = document.createElement('canvas')
  canvas.style.position = 'fixed'
  canvas.style.left = '0'
  canvas.style.top = '0'
  canvas.style.width = '100%'
  canvas.style.height = '100%'
  canvas.style.pointerEvents = 'none'
  canvas.style.zIndex = '9999'
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  return canvas
}

export default function launchConfetti(x = window.innerWidth / 2, y = window.innerHeight / 2) {
  const canvas = createCanvas()
  const ctx = canvas.getContext('2d')
  if (!ctx) return
  document.body.appendChild(canvas)

  const particles = []
  const colors = ['#ff595e', '#ffca3a', '#8ac926', '#1982c4', '#6a4c93']

  const count = 80
  for (let i = 0; i < count; i++) {
    particles.push({
      x,
      y,
      size: Math.random() * 8 + 4,
      color: colors[Math.floor(Math.random() * colors.length)],
      vx: (Math.random() - 0.5) * 8,
      vy: (Math.random() - 1.5) * 8,
      rot: Math.random() * Math.PI,
      vr: (Math.random() - 0.5) * 0.2,
      life: Math.random() * 60 + 60,
    })
  }

  let frame = 0

  function resize() {
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight
  }

  window.addEventListener('resize', resize)

  function render() {
    frame++
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    for (let i = particles.length - 1; i >= 0; i--) {
      const p = particles[i]
      p.x += p.vx
      p.y += p.vy
      p.vy += 0.2 // gravity
      p.rot += p.vr
      p.life--

      ctx.save()
      ctx.translate(p.x, p.y)
      ctx.rotate(p.rot)
      ctx.fillStyle = p.color
      ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size)
      ctx.restore()

      if (p.life <= 0 || p.y > canvas.height + 50) particles.splice(i, 1)
    }

    if (particles.length > 0 && frame < 1000) {
      requestAnimationFrame(render)
    } else {
      window.removeEventListener('resize', resize)
      canvas.remove()
    }
  }

  requestAnimationFrame(render)
}