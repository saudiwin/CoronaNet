fetch('articles.json')
    .then(response => response.json())
    .then(data => {
        Object.values(data).forEach(obj => displayData(obj))
    })

function displayData(item) {

    const titleLink = document.createElement('a')
    titleLink.className = 'title'
    titleLink.innerText = item.title
    titleLink.href = item.link

    const title = document.createElement('h3')


    title.appendChild(titleLink)

    const description = document.createElement('p')
    description.innerText = item.description
    description.className = 'block'

    const citationBlock = document.createElement('div')
    citationBlock.style.marginBottom = '20px'

    const panel = document.getElementById('citations-wrapper')

    citationBlock.appendChild(title)
    citationBlock.appendChild(description)
    panel.appendChild(citationBlock)
}