<?cs include:"header.cs" ?>
<h1>HELP!</h1>
<p>このページには、Aspen上で書いたプログラムがうまく動作せず、悩んでいる人を支援するために、よくある質問とそれに対する回答が書かれています。</p>
<ul>
<li><a href="#run">"Run" ボタンを押してもプログラムが実行されない学生諸君、┓(´_`)┏</a></li>
</ul>
<section id="run">
<div class="page-header">
<h2>"Run" ボタンを押してもプログラムが実行されない学生諸君へ</h2>
</div>
<p>Run ボタンを押して、うまく実行されない場合、多くは、皆さんが書いたプログラムにバグ（ミス）があることが原因なんですね。まずは、下記の間違いが、書いたプログラムにないかを、確認してみましょう！</p>
<p>p(・ω・*q)ガン(p*・ω・)q”バレ　p(・ω・*q)ガン(p*・ω・)q”バレ</p>
<h3>間違いその1:  {}の数が合わない</h3>
<p>これは最も多い間違いです (- ” -;) ウーン。</p>
<h4>■ if-else のブロックにとじるカッコ"}" がない.</h4>
<span class="label label-important">&times;</span>
<pre>
if () {
} else if () {
} else {
^ &lt;- 抜けている
</pre>
<h5>&lt;確認&gt; クラスのカッコは対応していますか？</h5>
<pre>
public class Exec8_1 {

}
</pre>
<h5>&lt;確認&gt; クラスのメインメソッドのカッコは対応していますか？</h5>
<pre>
public static void main (String[] args) {
}
</pre>
<p>カッコの対応が取れていないと、エラーも正確に出ない場合があるので、まず始めに見直しましょう。</p>
<h3>間違いその2:  () の開始または、終了カッコが抜けている</h3>
<p>これは、分かりやすい間違いです。(;・д・) 必ず見つけましょう。</p>
<h4>■ if () {} 文での "(" または ")" が抜けている場合は動作しません。</h4>
<span class="label label-important">&times;</span>
<pre>
if ( a &gt; b
</pre>
<h4>■ メソッド文での "(" または ")" が抜けている場合は動作しません。</h4>
<span class="label label-important">&times;</span>
<pre>public static int method (</pre>
<pre>public static int method )</pre>
<p>※ こういう間違いは無さそうで、あるのです。</p>
<h3>間違いその3:  修飾子の付け方が間違っている</h3>
<p>修飾子は案外重要なので、間違いのないように記述しましょう。_(._.)_</p>
<h4>■ メソッドの呼び出しに class 修飾子がついている</h4>
<span class="label label-important">&times;</span>
<pre>public class int method  (int d)</pre>
<p>メソッドに class 修飾子はつきません。public static int method (int d) のように、class 修飾子をつけずに記述してください。</p>
<h4>■ 確認：メソッドの呼び出しに public 修飾子が抜けていないか？</h4>
<span class="label label-important">&times;</span>
<pre>static int method2 (int a)</pre>
<h4>■ 確認：クラスの呼び出しに static がついていないか？</h4>
<span class="label label-important">&times;</span>
<pre>public static class Exec1</pre>
<h4>■ 基本の書き方：</h4>
<pre>
public class ClassName {
    public static void main (String[] args) {
          /* メインの処理 */
    }
    public static 型 メソッド（型 引数) {
         /* メソッドの処理 */
    }
     public static int[]  method (int a) {
        /* メソッドの処理 */
    }
}
</pre>
<h3>間違いその4:  文の終わりに “; “が抜けている,</h3>
<p>これが抜けていると、プログラムが終了せず、"Run" ボタンを押しても
何も表示されません。(οдО;)。</p>
<h4>■ Java 言語は, 必ず文の終わりに ";" をつける必要があります。</h4>
<span class="label label-important">&times;</span>
<pre>
return d
        ^
</pre>
<h3>間違いその5:  return 文で複数の変数を返している</h3>
<p>return はそれほど器用ではありません。注意しましょう。(￣- ￣ ) ンー.</p>
<h4>■ Java 言語は, return 文にて複数の値を返すことはできません。</h4>
<span class="label label-important">&times;</span>
<pre>
return a, b;
</pre>
<p>複数の値を返したい場合は, 配列にして, 一つの配列の変数を返すようにしましょう。</p>
<span class="label label-success">○</span>
<pre>
int[4] a = {1,2,3,4};
return a;
</pre>
<p>※ ただし、配列を return で返す場合は [] を省略する必要があります。</p>
<h3>それでも動作しない方: この見直しをしても、動作しない場合：</h3>
<p>何かが間違っています。。。きっと。一緒に探しましょう。この場合には、</p>
<pre>aspen-konoha'AT'google.com (AT は @に変換）</pre>
<p>まで、動作しないプログラムのURLと、Aspen ID を書いてメールをしてください。</p>
</section>
<?cs include:"footer.cs" ?>
