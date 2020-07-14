import { faCaretLeft } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import classnames from 'classnames'
import React, { useEffect, useState } from 'react'
import { shallowEqual, useDispatch, useSelector } from 'react-redux'
import { RouteComponentProps, useHistory } from 'react-router-dom'

import Loader from 'MainApp/components/Loader'
import QuestionsManager from 'MainApp/components/QuestionsManager'
import TestEditModal from 'MainApp/components/TestEditModal'
import Toggle from 'MainApp/components/Toggle'
import WarningModal from 'MainApp/components/WarningModal'
import { deleteTest, getTest, updateTest } from 'MainApp/modules/test/test'
import { RootState } from 'MainApp/rootReducer'
import { IdParams } from '../RefereeProfile/types'

import ActionsButton from './ActionsButton'
import Details from './Details'

enum SelectedTab {
  Details = 'details',
  Questions = 'questions'
}

enum ActiveModal {
  Edit = 'edit',
  Delete = 'delete'
}

const NewTest = (props: RouteComponentProps<IdParams>) => {
  const { match: { params: { id } } } = props

  const [selectedTab, setSelectedTab] = useState<SelectedTab>(SelectedTab.Details)
  const [activeModal, setActiveModal] = useState<ActiveModal>(null)
  const dispatch = useDispatch()
  const history = useHistory()
  const { test, isLoading } = useSelector((state: RootState) => state.test, shallowEqual)
  const isSelected = (tab: SelectedTab) => selectedTab === tab

  useEffect(() => {
    dispatch(getTest(id))
  }, [id])

  const handleBackClick = () => history.goBack()

  const handleToggle = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newTest = { active: event.currentTarget.checked }
    dispatch(updateTest(id, newTest))
  }

  const handleImportClick = () => history.push(`/import/test_${id}`)
  const handleTabClick = (newTab: SelectedTab) => () => {
    if (newTab === selectedTab) return null

    setSelectedTab(newTab)
  }
  const handleModalClick = (newModal: ActiveModal) => () => setActiveModal(newModal)
  const handleModalClose = () => setActiveModal(null)
  const handleDelete = () => {
    dispatch(deleteTest(id))
    handleBackClick()
  }

  const renderContent = () => {
    switch(selectedTab) {
      case SelectedTab.Details:
        return <Details test={test} />
      case SelectedTab.Questions:
        return <QuestionsManager testId={id} />
      default:
        return null
    }
  }

  const renderModals = () => {
    switch(activeModal) {
      case ActiveModal.Edit:
        return (
          <TestEditModal
            testId={test.id}
            open={true}
            showClose={true}
            onClose={handleModalClose}
            shouldUpdateTests={false}
          />
        )
      case ActiveModal.Delete:
        return (
          <WarningModal
            open={true}
            action="delete"
            dataType="test"
            onCancel={handleModalClose}
            onConfirm={handleDelete}
          />
        )
    }
  }

  return (
    <>
      <div className="w-5/6 mx-auto my-8">
        <button className="block" onClick={handleBackClick}>
          <FontAwesomeIcon icon={faCaretLeft} className="mr-2" />
          back
        </button>
        <div className="w-full flex justify-end items-center">
          <div className="flex w-1/2 items-center">
            <h1 className="text-3xl font-extrabold text-right mr-4">{test?.attributes.name}</h1>
            <Toggle name="active" onChange={handleToggle} checked={test?.attributes.active || false} />
          </div>
          <ActionsButton
            onImportClick={handleImportClick}
            onEditClick={handleModalClick(ActiveModal.Edit)}
            onDeleteClick={handleModalClick(ActiveModal.Delete)}
          />
        </div>
        <div className="w-5/6 h-screen my-8 mx-auto">
          <div className="tab-row">
            <button
              className={classnames({ 'tab-selected': isSelected(SelectedTab.Details) })}
              onClick={handleTabClick(SelectedTab.Details)}
            >
              Details
            </button>
            <button
              className={classnames({ 'tab-selected': isSelected(SelectedTab.Questions) })}
              onClick={handleTabClick(SelectedTab.Questions)}
            >
              Question Manager
            </button>
          </div>
          <div className="border border-t-0 p-4">
            {isLoading ? <Loader /> : renderContent()}
          </div>
        </div>
      </div>
      {renderModals()}
    </>
  )
}

export default NewTest
