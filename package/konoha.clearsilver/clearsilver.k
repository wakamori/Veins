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

// **************************************************************************
// LIST OF CONTRIBUTERS
//  chen_ji - Takuma Wakamori, Yokohama National University, Japan
// **************************************************************************

include "lib:gluelink";

/* ------------------------------------------------------------------------ */
// [classes]
@Native class Hdf;
@Native class Cs;

@Native Hdf Hdf.new();
@Native Hdf Hdf.getObj(String name);
@Native Hdf Hdf.objChild();
@Native Hdf Hdf.objNext();
@Native String Hdf.objName();
@Native int Hdf.getIntValue(String name);
@Native @Overload String Hdf.getValue(String name);
@Overload int Hdf.getValue(String name) {
    this.getIntValue(name);
}
@Native void Hdf.setIntValue(String name, int value);
@Native @Overload void Hdf.setValue(String name, String value);
@Overload void Hdf.setValue(String name, int value) {
    this.setIntValue(name, value);
}
@Native void Hdf.readFile(Path path);
@Native void Hdf.readString(String s);
@Native void Hdf.writeFile(Path path);
@Native void Hdf.writeFileAtomic(Path path);
@Native void Hdf.dump(String prefix);

@Native Cs Cs.new(Hdf hdf);
@Native void Cs.parseFile(Path path);
@Native void Cs.parseString(String buf);
@Native void Cs.render(Func<String=>int> cb);
@Native void Cs.dump(Func<String=>int> cb);
