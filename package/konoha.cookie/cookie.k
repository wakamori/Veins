/****************************************************************************
 * KONOHA COPYRIGHT, LICENSE NOTICE, AND DISCRIMER
 *
 * Copyright (c)  2010-      Konoha Team konohaken@googlegroups.com
 * All rights reserved.
 *
 * You may choose one of the following two licenses when you use konoha.
 * See www.konohaware.org/license.html for further information.
 *
 * (1) GNU Lesser General Public License 3.0 (with KONOHA_UNDER_LGPL3)
 * (2) Konoha Software Foundation License 1.0
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

include "lib:gluelink";

@Native @Public int Date.getYear();
@Native @Public void Date.setYear(int year);
@Native @Public int Date.getMonth();
@Native @Public void Date.setMonth(int month);
@Native @Public int Date.getDay();
@Native @Public void Date.setDay(int day);
@Native @Public int Date.getHour();
@Native @Public void Date.setHour(int hour);
@Native @Public int Date.getMin();
@Native @Public void Date.setMin(int min);
@Native @Public int Date.getSec();
@Native @Public void Date.setSec(int sec);
@Native @Public int Date.getGmtoff();
@Native @Public void Date.setGmtoff(int gmtoff);
@Native @Public String Date.toRFC1123();

class Cookie
{
    Map<string,Map<string,string>> m;

    Cookie(string arg) {
        m = new Map<string,Map<string,string>>(0);
        if (arg != "") {
            string[] a = arg.replace($/ /, "").split(";");
            foreach (string s in a) {
                string[] kv = s.split("=");
                m[kv[0]] = {"val": kv[1], "expires": "", "path": ""};
            }
        }
    }

    void set(string key, string val) {
        m[key] = {"val": val, "expires": "", "path": ""};
    }

    Map<string,string> get(string key) {
        return m[key];
    }

    void delete(String key) {
        this[key] = "";
        this[key]["expires"] = "Thu, 01 Jan 1970 00:00:00 GMT";
        if (this[key]["path"] == null) {
            this[key]["path"] = "/";
        }
    }

    string dump(void) {
        string ret = "";
        foreach (string key in m.keys()) {
            ret += "Set-Cookie: ";
            ret += key + "=" + m[key]["val"];
            if (m[key]["expires"] != "") {
                ret += "; expires=" + m[key]["expires"];
            }
            if (m[key]["path"] != "") {
                ret += "; Path=" + m[key]["path"];
            }
            ret += "\n";
        }
        return ret;
    }
}
