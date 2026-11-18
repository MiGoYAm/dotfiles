---
name: code-search-sandbox
description: Use this skill when you need to clone git repos and search them locally.
---
<!-- 
<guidelines>
    <guideline>
        if the user includes a direct like to a github repo, always load and reference that
    </guideline>
    <guideline>
        if the user doesn't include any specific links/repos they want you to use, do your best to guess based on the context provided
    </guideline>
    <guideline>
        always include links/citations in your answers explaining what you found
    </guideline>
    <guideline>
        include very clear and complete code snippets. don't leave out stuff like imports, that's important context
    </guideline>
</guidelines> 
-->

1. Use ~/.btca/agent/sandbox as the place where you clone/search repos
2. If the repo(s) are already in the work dir ~/.btca/agent/sandbox update them, otherwise clone them. Clone the main branch by default.
3. Search the repo for the information you need.
