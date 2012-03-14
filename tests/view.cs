<!DOCTYPE html>
<html>
    <head>
        <title>
            <?cs var:Page.Title ?>
        </title>
    </head>
    <body>
        <ul>
            <?cs each:item = Page.Menu ?>
            <li>
                <a href="<?cs var:item.URL ?>">
                    <?cs var:item.Name ?>
                </a>
            </li>
            <?cs /each ?>
        </ul>
    </body>
</html>
