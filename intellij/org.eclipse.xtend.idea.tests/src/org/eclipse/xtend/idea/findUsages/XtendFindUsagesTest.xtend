/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtend.idea.findUsages

import com.intellij.find.FindManager
import com.intellij.find.findUsages.FindUsagesHandler
import com.intellij.find.impl.FindManagerImpl
import com.intellij.psi.PsiElement
import com.intellij.psi.PsiFile
import com.intellij.psi.PsiNamedElement
import com.intellij.psi.search.LocalSearchScope
import com.intellij.usageView.UsageInfo
import com.intellij.util.CommonProcessors
import org.eclipse.xtend.idea.LightXtendTest

import static extension com.intellij.codeInsight.highlighting.HighlightUsagesHandler.*
import static extension com.intellij.psi.util.PsiTreeUtil.*

/**
 * @author kosyakov - Initial contribution and API
 */
class XtendFindUsagesTest extends LightXtendTest {

	def void testFindUsagesWihtSourceElement_01() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			class MyClass {
			}
		''')
		val element = file.getNamedElementAt('MyClass')
		element.testFindUsages('''
			primaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Type_XtendClassAnnotationInfoAction_2_0_0_ELEMENT_TYPE)
			}
			secondaryElements {
				PsiClass:MyClass
			}
		''')
	}

	def void testFindUsagesWihtSourceElement_02() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			class MyClass {
			}
		''')
		myFixture.addFileToProject('mypackage/MyClass2.xtend', '''
			package mypackage
			
			class MyClass2 extends MyClass {
			}
		''')
		val element = file.getNamedElementAt('MyClass')
		element.testFindUsages('''
			primaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Type_XtendClassAnnotationInfoAction_2_0_0_ELEMENT_TYPE) {
					MyClass (class org.eclipse.xtext.psi.impl.XtextPsiReferenceImpl) {
						virtualFile : temp:///src/mypackage/MyClass2.xtend
						navigationOffset : 42
					}
				}
			}
			secondaryElements {
				PsiClass:MyClass {
					mypackage.MyClass (class com.intellij.psi.impl.source.PsiJavaCodeReferenceElementImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass2.java
						navigationOffset : 37
					}
					mypackage.MyClass (class com.intellij.psi.impl.source.PsiJavaCodeReferenceElementImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass2.java
						navigationOffset : 102
					}
				}
			}
		''')
	}

	def void testFindUsagesWihtSourceElement_03() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				int y
				def getX() {
					y
				}
			}
		''')

		file.getNamedElementAt('int x').testFindUsages('''
			primaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Member_XtendFieldAnnotationInfoAction_2_0_0_ELEMENT_TYPE)
			}
			secondaryElements {
				PsiField:x {
					this.x (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 304
					}
				}
				PsiMethod:setX
				PsiParameter:x {
					x (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 308
					}
				}
			}
		''')
	}

	def void testFindUsagesWihtSourceElement_04() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				int y
				def getX() {
					y
				}
			}
		''')

		file.getNamedElementAt('int y').testFindUsages('''
			primaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Member_XtendFieldAnnotationInfoAction_2_0_0_ELEMENT_TYPE) {
					y (class org.eclipse.xtext.psi.impl.XtextPsiReferenceImpl) {
						virtualFile : temp:///src/mypackage/MyClass.xtend
						navigationOffset : 128
					}
				}
			}
			secondaryElements {
				PsiField:y {
					this.y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 251
					}
					this.y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 364
					}
					this.y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 417
					}
				}
				PsiMethod:getY
				PsiMethod:setY
				PsiParameter:y {
					y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 421
					}
				}
			}
		''')
	}

	def void testFindUsagesWihtGeneratedElement_01() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			class MyClass {
			}
		''')
		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		val element = generatedSource.getNamedElementAt('MyClass')
		element.testFindUsages('''
			primaryElements {
				PsiClass:MyClass
			}
			secondaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Type_XtendClassAnnotationInfoAction_2_0_0_ELEMENT_TYPE)
			}
		''')
	}

	def void testFindUsagesWihtGeneratedElement_02() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			class MyClass {
			}
		''')
		myFixture.addFileToProject('mypackage/MyClass2.xtend', '''
			package mypackage
			
			class MyClass2 extends MyClass {
			}
		''')
		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		val element = generatedSource.getNamedElementAt('MyClass')
		element.testFindUsages('''
			primaryElements {
				PsiClass:MyClass {
					mypackage.MyClass (class com.intellij.psi.impl.source.PsiJavaCodeReferenceElementImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass2.java
						navigationOffset : 37
					}
					mypackage.MyClass (class com.intellij.psi.impl.source.PsiJavaCodeReferenceElementImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass2.java
						navigationOffset : 102
					}
				}
			}
			secondaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Type_XtendClassAnnotationInfoAction_2_0_0_ELEMENT_TYPE) {
					MyClass (class org.eclipse.xtext.psi.impl.XtextPsiReferenceImpl) {
						virtualFile : temp:///src/mypackage/MyClass2.xtend
						navigationOffset : 42
					}
				}
			}
		''')
	}

	def void testFindUsagesWihtGeneratedElement_03() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				int y
				def getX() {
					y
				}
			}
		''')

		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		generatedSource.getNamedElementAt('int x').testFindUsages('''
			primaryElements {
				PsiField:x {
					this.x (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 304
					}
				}
			}
			secondaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Member_XtendFieldAnnotationInfoAction_2_0_0_ELEMENT_TYPE)
			}
		''')
	}

	def void testFindUsagesWihtGeneratedElement_04() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				int y
				def getX() {
					y
				}
			}
		''')

		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		generatedSource.getNamedElementAt('int y').testFindUsages('''
			primaryElements {
				PsiField:y {
					this.y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 251
					}
					this.y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 364
					}
					this.y (class com.intellij.psi.impl.source.tree.java.PsiReferenceExpressionImpl) {
						virtualFile : temp:///src/xtend-gen/mypackage/MyClass.java
						navigationOffset : 417
					}
				}
			}
			secondaryElements {
				org.eclipse.xtext.psi.impl.PsiNamedEObjectImpl(Member_XtendFieldAnnotationInfoAction_2_0_0_ELEMENT_TYPE) {
					y (class org.eclipse.xtext.psi.impl.XtextPsiReferenceImpl) {
						virtualFile : temp:///src/mypackage/MyClass.xtend
						navigationOffset : 128
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithSourceElement_01() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
			}
		''')

		file.getNamedElementAt('int x').testHighlightUsages('''
			references {
			}
		''')
	}

	def void testHighlightUsagesWithSourceElement_02() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				def usageOfX() {
					x
				}
			}
		''')

		file.getNamedElementAt('int x').testHighlightUsages('''
			references {
				XtextPsiReferenceImpl {
					element : org.eclipse.xtext.psi.impl.PsiEObjectReference(XFeatureCall_FeatureJvmIdentifiableElementCrossReference_2_0_ELEMENT_TYPE)
					rangesToHighlight {
						(125,126)
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithSourceElement_03() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				def usageOfGetX() {
					getX
				}
			}
		''')

		file.getNamedElementAt('int x').testHighlightUsages('''
			references {
				XtextPsiReferenceImpl {
					element : org.eclipse.xtext.psi.impl.PsiEObjectReference(XFeatureCall_FeatureJvmIdentifiableElementCrossReference_2_0_ELEMENT_TYPE)
					rangesToHighlight {
						(128,132)
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithSourceElement_04() {
		val file = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				def usageOfX() {
					x
				}
				def usageOfGetX() {
					getX
				}
			}
		''')

		file.getNamedElementAt('int x').testHighlightUsages('''
			references {
				XtextPsiReferenceImpl {
					element : org.eclipse.xtext.psi.impl.PsiEObjectReference(XFeatureCall_FeatureJvmIdentifiableElementCrossReference_2_0_ELEMENT_TYPE)
					rangesToHighlight {
						(125,126)
					}
				}
				XtextPsiReferenceImpl {
					element : org.eclipse.xtext.psi.impl.PsiEObjectReference(XFeatureCall_FeatureJvmIdentifiableElementCrossReference_2_0_ELEMENT_TYPE)
					rangesToHighlight {
						(153,157)
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithGeneratedElement_01() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
			}
		''')

		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		generatedSource.getNamedElementAt('int x').testHighlightUsages('''
			references {
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(239,240)
					}
				}
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(292,293)
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithGeneratedElement_02() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				def usageOfX() {
					x
				}
			}
		''')

		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		generatedSource.getNamedElementAt('int x').testHighlightUsages('''
			references {
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(235,236)
					}
				}
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(291,292)
					}
				}
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(344,345)
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithGeneratedElement_03() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				def usageOfGetX() {
					getX
				}
			}
		''')

		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		generatedSource.getNamedElementAt('int x').testHighlightUsages('''
			references {
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(299,300)
					}
				}
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(352,353)
					}
				}
			}
		''')
	}

	def void testHighlightUsagesWithGeneratedElement_04() {
		val sourceFile = myFixture.addFileToProject('mypackage/MyClass.xtend', '''
			package mypackage
			
			import org.eclipse.xtend.lib.annotations.Accessors
			
			@Accessors class MyClass {
				int x
				def usageOfX() {
					x
				}
				def usageOfGetX() {
					getX
				}
			}
		''')

		val generatedSource = sourceFile.getGeneratedSources[extension == 'java'].head
		generatedSource.getNamedElementAt('int x').testHighlightUsages('''
			references {
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(235,236)
					}
				}
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(351,352)
					}
				}
				PsiReferenceExpression:this.x {
					element : PsiReferenceExpression:this.x
					rangesToHighlight {
						(404,405)
					}
				}
			}
		''')
	}

	protected def getNamedElementAt(PsiFile file, String substring) {
		val offset = file.text.indexOf(substring)
		file.findElementAt(offset).getParentOfType(PsiNamedElement, false)
	}

	protected def void testHighlightUsages(PsiElement element, String expectation) {
		assertEquals(expectation, element.highlightUsagesHandler.printHighlightUsages(element))
	}

	protected def String printHighlightUsages(FindUsagesHandler findUsagesHandler, PsiElement element) {
		val scope = new LocalSearchScope(element.containingFile)
		val references = findUsagesHandler.findReferencesToHighlight(element, scope)
		'''
			references {
				�FOR reference : references�
					�reference� {
						element : �reference.element�
						rangesToHighlight {
							�FOR rangeToHighlight : reference.rangesToHighlight�
								�rangeToHighlight�
							�ENDFOR�
						}
					}
				�ENDFOR�
			}
		'''
	}

	protected def void testFindUsages(PsiElement element, String expectation) {
		assertEquals(expectation, element.findUsagesHandler.printUsages)
	}

	protected def String printUsages(FindUsagesHandler findUsagesHandler) {
		val primaryElements = findUsagesHandler.primaryElements
		val secondaryElements = findUsagesHandler.secondaryElements
		'''
			primaryElements {
				�findUsagesHandler.printUsages(primaryElements)�
			}
			secondaryElements {
				�findUsagesHandler.printUsages(secondaryElements)�
			}
		'''
	}

	protected def String printUsages(FindUsagesHandler findUsagesHandler, PsiElement ... elements) '''
		�FOR element : elements�
			�element��val usages = findUsagesHandler.findUsages(element)��IF !usages.empty� {
				�FOR usage : usages�
					�usage� {
						virtualFile : �usage.virtualFile�
						navigationOffset : �usage.navigationOffset�
					}
				�ENDFOR�
			}�ENDIF�
		�ENDFOR�
	'''

	protected def findUsages(FindUsagesHandler findUsagesHandler, PsiElement ... elements) {
		val processor = new CommonProcessors.CollectProcessor<UsageInfo>
		val options = findUsagesHandler.getFindUsagesOptions(null)
		for (element : elements)
			findUsagesHandler.processElementUsages(element, processor, options)
		processor.results
	}

	protected def getHighlightUsagesHandler(PsiElement element) {
		findManager.findUsagesManager.getFindUsagesHandler(element, true)
	}

	protected def getFindUsagesHandler(PsiElement element) {
		findManager.findUsagesManager.getFindUsagesHandler(element, false)
	}

	protected def getFindManager() {
		FindManager.getInstance(myFixture.project) as FindManagerImpl
	}

}