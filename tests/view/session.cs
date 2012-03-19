<?cs include:"header.cs" ?>
    <h1>Session test</h1>
    <button onclick="javascript:location.reload()">Reload</button>
    <form action="<?cs var:BASE_URL ?><?cs var:Navigation.1.URL ?>" method="post">
        <input type="hidden" name="type" value="renew">
        <input type="submit" value="Renew">
    </form>
    <p>session ID: <?cs var:Session.ID ?></p>
    <table>
        <caption>
            Session values
        </caption>
        <thead>
            <tr><th>key</th><th>value</th></tr>
        </thead>
        <tbody>
            <?cs each:item = Session.Items ?>
            <tr><td><?cs var:item.key ?></td><td><?cs var:item.value ?></td></tr>
            <?cs /each ?>
        </tbody>
    </table>
    <h2>Set a new value</h2>
        <form action="<?cs var:BASE_URL ?><?cs var:Navigation.1.URL ?>" method="post">
            <input type="hidden" name="type" value="set">
            key:<input type="text" name="key"><br>
            value:<input type="text" name="value"><br>
        <input type="submit" value="Set">
    </form>
    <h2>Remove a value</h2>
        <form action="<?cs var:BASE_URL ?><?cs var:Navigation.1.URL ?>" method="post">
            <input type="hidden" name="type" value="remove">
            key:<input type="text" name="key"><br>
        <input type="submit" value="Remove">
<?cs include:"footer.cs" ?>
