<?cs include:"header.cs" ?>
    <h1>Request parameter test</h1>
    <p>Request: <?cs var:method ?></p>
    <table>
        <caption>
            Request parameters.
        </caption>
        <thead>
            <tr><th>key</th><th>value</th></tr>
        </thead>
        <tbody>
            <?cs each:item = Items ?>
            <tr><td><?cs var:item.key ?></td><td><?cs var:item.value ?></td></tr>
            <?cs /each ?>
        </tbody>
    </table>
    <h2>POST request test</h2>
    <form action="<?cs var:BASE_URL ?><?cs var:Navigation.2.URL ?>" method="post">
        name:<input type="text" name="name"><br>
        text:<textarea name="text"></textarea><br>
        <input type="submit" value="send">
    </form>
    <h2>GET request test</h2>
    <p>goto: <a href="<?cs var:BASE_URL ?><?cs var:Navigation.2.URL ?>?key=value&kanji=あいうえお"><?cs var:BASE_URL ?><?cs var:Navigation.2.URL ?>?key=value&kanji=あいうえお</a></p>
<?cs include:"footer.cs" ?>
